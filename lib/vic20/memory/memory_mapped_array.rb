require 'ffi'

module Vic20
  class Memory
    class MemoryMappedArray
      PROT_NONE  = 0x00
      PROT_READ  = 0x01
      PROT_WRITE = 0x02
      PROT_EXEC  = 0x04

      MAP_SHARED  = 0x0001
      MAP_PRIVATE = 0x0002
      MAP_FIXED   = 0x0010

      MAP_FILE    = 0x0000
      MAP_ANON    = 0x1000

      MADV_NORMAL     = 0
      MADV_RANDOM     = 1
      MADV_SEQUENTIAL = 2

      extend FFI::Library

      ffi_lib [FFI::CURRENT_PROCESS, 'c']

      # sys/mman.h
      attach_function :madvise, [:pointer, :size_t, :int], :int
      attach_function :mmap, [:pointer, :size_t, :int, :int, :int, :off_t], :pointer
      attach_function :munmap, [:pointer, :size_t], :int

      private :madvise
      private :mmap
      private :munmap

      def initialize(size)
        @bytes = mmap(nil, size, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANON, -1, 0)
      end

      def [](index, length = nil)
        if length
          @bytes.get_array_of_uchar(index, length)
        else
          @bytes.get_uchar(index)
        end
      end

      def []=(index, length, value = nil)
        if value
          @bytes.put_array_of_uchar(index, value)
        else
          @bytes.put_uchar(index, length)
        end
      end
    end
  end
end
