require 'ffi'

module IPC
  class Semaphore
    extend FFI::Library

    ffi_lib [FFI::CURRENT_PROCESS, 'c']

    # errno.h
    attach_variable :errno, :int

    # string.h
    attach_function :strerror, [:int], :string

    private :strerror

    # sys/sem.h
    # Structure of array element for second argument to semop
    class Sembuf < FFI::Struct
      layout :sem_num, :ushort, # semaphore #
             :sem_op,  :short,  # semaphore operation
             :sem_flg, :short   # operation flags
    end

    class IpcPerm < FFI::Struct
      layout :uid,  :uid_t,  # Owner's user ID
             :gid,  :gid_t,  # Owner's group ID
             :cuid, :uid_t,  # Creator's user ID
             :cgid, :gid_t,  # Creator's group ID
             :mode, :mode_t, # Read/write permission
             :_seq, :ushort, # Reserved for internal use
             :_key, :key_t   # Reserved for internal use
    end

    class Sem < FFI::Struct
      layout :semval, :ushort,  # semaphore value
             :sempid, :pid_t,   # pid of last operation
             :semncnt, :ushort, # # awaiting semval > cval
             :semzcnt, :ushort  # # awaiting semval == 0
    end

    class SemidDs < FFI::Struct
      layout :sem_perm,  IpcPerm,    # operation permission struct
             :sem_base,  :int32,     # pointer to first semaphore in set
             :sem_nsems, :ushort,    # number of sems in set
             :sem_otime, :time_t,    # last operation time
             :sem_pad1,  :int32,     # SVABI/386 says I need this here
             :sem_ctime, :time_t,    # last change time
             :sem_pad2,  :int32,     # SVABI/386 says I need this here
             :sem_pad3,  [:int32, 4] # SVABI/386 says I need this here
    end

    class Semun < FFI::Union
      layout :val,   :int,        # value for SETVAL
             :buf,   SemidDs.ptr, # buffer for IPC_STAT & IPC_SET
             :array, :pointer     # array for GETALL & SETALL
    end

    attach_function :semctl, :semctl, [:int, :int, :int], :int
    attach_function :semctl_ex, :semctl, [:int, :int, :int, Semun.by_value], :int
    attach_function :semget, [:key_t, :int, :int], :int
    attach_function :semop, [:int, Sembuf.ptr, :size_t], :int

    private :semctl
    private :semget
    private :semop

    # Possible values for the third argument to semctl
    GETNCNT = 3 # Return the value of semncnt {READ}
    GETPID  = 4 # Return the value of sempid {READ}
    GETVAL  = 5 # Return the value of semval {READ}
    GETALL  = 6 # Return semvals into arg.array {READ}
    GETZCNT = 7 # Return the value of semzcnt {READ}
    SETVAL  = 8 # Set the value of semval to arg.val {ALTER}
    SETALL  = 9 # Set semvals from arg.array {ALTER}

    # Mode bits
    IPC_CREAT   = 0o001000 # Create entry if key does not exist
    IPC_EXCL    = 0o002000 # Fail if key exists
    IPC_NOWAIT  = 0o004000 # Error if request must wait

    # Keys
    IPC_PRIVATE = 0 # Private key

    # Control commands
    IPC_RMID    = 0 # Remove identifier
    IPC_SET     = 1 # Set options
    IPC_STAT    = 2 # Get options

    # Possible flag values for sem_flg
    SEM_UNDO    = 0o010000 # Set up adjust on exit entry

    # Permissions
    SEM_A       = 0o0200 # alter permission
    SEM_R       = 0o0400 # read permission

    class << self
      def finalize(semid)
        proc do
          semctl(semid, 0, IPC_RMID)
        end
      end
    end

    class SemaphoreProxy < Semaphore
      def initialize(semaphore, index)
        @semaphore = semaphore
        @index = index
      end

      def value
        @semaphore.get(@index)
      end

      def value=(value)
        @semaphore.set(@index, value)
      end

      def release(count = 1)
        @semaphore.release(index: @index, count: count)
      end

      def try_wait(count = 1)
        @semaphore.try_wait(index: @index, count: count)
      end

      def wait(count = 1)
        @semaphore.wait(index: @index, count: count)
      end

      def waiting_for_value
        @semaphore.waiting_for_value(index: @index)
      end

      def waiting_for_zero
        @semaphore.waiting_for_zero(index: @index)
      end
    end

    def initialize(count: 1, key: IPC_PRIVATE, mode: SEM_R | SEM_A | IPC_CREAT)
      @semid = semget(key, count, mode)
      raise SystemCallError, errno if @semid == -1
      @proxies = Array.new(count) { |index| SemaphoreProxy.new(self, index) }
      ObjectSpace.define_finalizer(self, self.class.finalize(@semid))
    end

    def count
      arg = Semun.new
      arg[:buf] = SemidDs.new
      handle_result semctl_ex(@semid, 0, IPC_STAT, arg)
      arg[:buf][:sem_nsems]
    end

    def [](index)
      SemaphoreProxy.new(self, index)
    end

    def get(index)
      handle_result semctl(@semid, index, GETVAL)
    end

    def set(index, value)
      arg = Semun.new
      arg[:val] = value
      handle_result semctl_ex(@semid, index, SETVAL, arg), returning: value
    end

    def release(index:, count:)
      handle_result _sem_op(index: index, sem_op: count), returning: true
    end

    def try_wait(index:, count:)
      handle_result _sem_op(index: index, sem_op: -count, sem_flg: IPC_NOWAIT), returning: true, ignoring: Errno::EAGAIN::Errno
    end

    def wait(index:, count:)
      handle_result _sem_op(index: index, sem_op: -count), returning: true
    end

    def waiting_for_value(index:)
      handle_result semctl(@semid, index, GETNCNT)
    end

    def waiting_for_zero(index:)
      handle_result semctl(@semid, index, GETZCNT)
    end

    private

    def _sem_op(index:, sem_op:, sem_flg: 0)
      sops = Sembuf.new
      sops[:sem_num] = index
      sops[:sem_op]  = sem_op
      sops[:sem_flg] = sem_flg
      semop(@semid, sops, 1)
    end

    def handle_result(result, returning: result, ignoring: [])
      return returning unless result == -1
      raise SystemCallError, self.class.errno unless Array(ignoring).include?(self.class.errno)
    end
  end
end
