#ifndef DYDX_V4_PROTO_EXPORT_H
#define DYDX_V4_PROTO_EXPORT_H

#if defined(_MSC_VER)
    #ifdef dydx_v4_proto_EXPORTS
        #define DYDX_V4_PROTO_EXPORT __declspec(dllexport)
    #else
        #define DYDX_V4_PROTO_EXPORT __declspec(dllimport)
    #endif
#else
    #define DYDX_V4_PROTO_EXPORT
#endif

    #ifdef dydx_v4_proto_EXPORTS
      // Force export of problematic templates
      #include <atomic>
      #include <string>
      #include <memory>
      #include <google/protobuf/io/coded_stream.h>
      #include <google/protobuf/serial_arena.h>
      #include <google/protobuf/thread_safe_arena.h>
      #include <google/protobuf/arenastring.h>
      #include <google/protobuf/metadata_lite.h>
      #include <google/protobuf/message_lite.h>
      #include <google/protobuf/extension_set.h>
      #include <google/protobuf/descriptor.h>
      #include <google/protobuf/io/zero_copy_stream_impl_lite.h>
      #include <absl/synchronization/mutex.h>
      #include <absl/container/flat_hash_map.h>
      #include <absl/strings/cord.h>
      #include <absl/strings/cord_buffer.h>

      // Atomic types
      template class DYDX_V4_PROTO_EXPORT std::atomic<bool>;
      template class DYDX_V4_PROTO_EXPORT std::atomic<char*>;
      template class DYDX_V4_PROTO_EXPORT std::atomic<unsigned __int64>;
      template class DYDX_V4_PROTO_EXPORT std::atomic<int>;
      template class DYDX_V4_PROTO_EXPORT std::atomic<google::protobuf::internal::StringBlock*>;
      template class DYDX_V4_PROTO_EXPORT std::atomic<google::protobuf::internal::ArenaBlock*>;
      template class DYDX_V4_PROTO_EXPORT std::atomic<google::protobuf::internal::ThreadSafeArena::SerialArenaChunk*>;
      template class DYDX_V4_PROTO_EXPORT std::atomic<const std::string*>;
      template class DYDX_V4_PROTO_EXPORT std::atomic<google::protobuf::internal::ExtensionSet::LazyMessageExtension*(__cdecl*)(google::protobuf::Arena*)>;

      // Google Protobuf types
      template class DYDX_V4_PROTO_EXPORT google::protobuf::internal::TaggedAllocationPolicyPtr;
      template class DYDX_V4_PROTO_EXPORT google::protobuf::internal::ThreadSafeArenaStatsHandle;
      template class DYDX_V4_PROTO_EXPORT google::protobuf::RepeatedField<int>;
      template class DYDX_V4_PROTO_EXPORT google::protobuf::RepeatedField<int64_t>;
      template class DYDX_V4_PROTO_EXPORT google::protobuf::RepeatedField<uint32_t>;
      template class DYDX_V4_PROTO_EXPORT google::protobuf::RepeatedField<uint64_t>;
      template class DYDX_V4_PROTO_EXPORT google::protobuf::RepeatedField<double>;
      template class DYDX_V4_PROTO_EXPORT google::protobuf::RepeatedField<float>;
      template class DYDX_V4_PROTO_EXPORT google::protobuf::RepeatedField<bool>;

      // Abseil types
      template class DYDX_V4_PROTO_EXPORT absl::lts_20240722::Mutex;
      template class DYDX_V4_PROTO_EXPORT absl::lts_20240722::flat_hash_map<std::string, bool, absl::lts_20240722::container_internal::StringHash, absl::lts_20240722::container_internal::StringEq, std::allocator<std::pair<const std::string, bool>>>;
      template class DYDX_V4_PROTO_EXPORT absl::lts_20240722::Cord;
      template class DYDX_V4_PROTO_EXPORT absl::lts_20240722::CordBuffer;
      template class DYDX_V4_PROTO_EXPORT absl::lts_20240722::Cord::CharIterator;

      // Standard library types
      template class DYDX_V4_PROTO_EXPORT std::basic_string<char, std::char_traits<char>, std::allocator<char>>;
      template class DYDX_V4_PROTO_EXPORT std::unique_ptr<uint8_t[], std::default_delete<uint8_t[]>>;
      template class DYDX_V4_PROTO_EXPORT std::unique_ptr<google::protobuf::DescriptorPool::Tables, std::default_delete<google::protobuf::DescriptorPool::Tables>>;
      template class DYDX_V4_PROTO_EXPORT std::unique_ptr<google::protobuf::FeatureSetDefaults, std::default_delete<google::protobuf::FeatureSetDefaults>>;
      template class DYDX_V4_PROTO_EXPORT std::unique_ptr<absl::lts_20240722::AnyInvocable<void(absl::lts_20240722::FunctionRef<void(void)>) const>, std::default_delete<absl::lts_20240722::AnyInvocable<void(absl::lts_20240722::FunctionRef<void(void)>) const>>>;

    #endif
#endif // DYDX_V4_PROTO_EXPORT_H
