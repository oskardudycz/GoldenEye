using GoldenEye.Events.External;
using GoldenEye.Kafka.Consumers;
using GoldenEye.Kafka.Producers;
using GoldenEye.Registration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using System.Linq;

namespace GoldenEye.Kafka.Registrations
{
    public static class Config
    {

        public static IServiceCollection AddKafkaProducer(this IServiceCollection services)
        {
            //removing NulloExternalEventProducer added by default
            var serviceDescriptor = services.FirstOrDefault(descriptor => descriptor.ServiceType == typeof(IExternalEventProducer));
            services.Remove(serviceDescriptor);

            //using TryAdd to support mocking, without that it won't be possible to override in tests
            services.TryAddScoped<IExternalEventProducer, KafkaProducer>();
            return services;
        }

        public static IServiceCollection AddKafkaConsumer(this IServiceCollection services)
        {
            //using TryAdd to support mocking, without that it won't be possible to override in tests
            services.TryAddSingleton<IExternalEventConsumer, KafkaConsumer>();

            return services.AddExternalEventConsumerBackgroundWorker();
        }

        public static IServiceCollection AddKafkaProducerAndConsumer(this IServiceCollection services)
        {
            return services
                .AddKafkaProducer()
                .AddKafkaConsumer();
        }
    }
}
