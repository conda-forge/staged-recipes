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

/*
    #ifdef dydx_v4_proto_EXPORTS
        #include <string>
        #include <atomic>
        #include <google/protobuf/message.h>
        #include <absl/synchronization/mutex.h>
        #include <absl/strings/cord.h>

        // Explicit exports for problematic symbols
        extern template class DYDX_V4_PROTO_EXPORT std::atomic<bool>;
        extern template class DYDX_V4_PROTO_EXPORT std::atomic<char*>;
        extern template class DYDX_V4_PROTO_EXPORT std::atomic<unsigned __int64>;
        extern template class DYDX_V4_PROTO_EXPORT std::atomic<int>;
        extern template class DYDX_V4_PROTO_EXPORT std::atomic<google::protobuf::internal::StringBlock*>;
        extern template class DYDX_V4_PROTO_EXPORT std::atomic<google::protobuf::internal::ArenaBlock*>;
        extern template class DYDX_V4_PROTO_EXPORT std::atomic<google::protobuf::internal::ThreadSafeArena::SerialArenaChunk*>;
        extern template class DYDX_V4_PROTO_EXPORT std::atomic<const std::string*>;
        extern template class DYDX_V4_PROTO_EXPORT std::atomic<google::protobuf::internal::ExtensionSet::LazyMessageExtension*(*)(google::protobuf::Arena*)>;

        // Non-template class exports
        class DYDX_V4_PROTO_EXPORT google::protobuf::internal::TaggedAllocationPolicyPtr;
        class DYDX_V4_PROTO_EXPORT google::protobuf::internal::ThreadSafeArenaStatsHandle;
        class DYDX_V4_PROTO_EXPORT absl::lts_20240722::Mutex;
        class DYDX_V4_PROTO_EXPORT absl::lts_20240722::Cord;
        class DYDX_V4_PROTO_EXPORT absl::lts_20240722::CordBuffer;
        class DYDX_V4_PROTO_EXPORT absl::lts_20240722::Cord::CharIterator;

        // Specific function exports
    #endif
*/
#endif // DYDX_V4_PROTO_EXPORT_H
