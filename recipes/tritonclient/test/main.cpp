#include <grpc_client.h>
#include <http_client.h>

#include <memory>

int main()
{
  std::unique_ptr<triton::client::InferenceServerGrpcClient> grpc_client;
  std::unique_ptr<triton::client::InferenceServerHttpClient> http_client;
  const auto grpc_error = triton::client::InferenceServerGrpcClient::Create(
      &grpc_client, "localhost:8001");
  const auto http_error = triton::client::InferenceServerHttpClient::Create(
      &http_client, "localhost:8000");
  return (grpc_error.IsOk() && http_error.IsOk()) ? 0 : 1;
}
