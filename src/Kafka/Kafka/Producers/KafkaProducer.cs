using System;
using System.Threading;
using System.Threading.Tasks;
using Confluent.Kafka;
using Core.Streaming.Kafka.Producers;
using GoldenEye.Events;
using GoldenEye.Events.External;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;

namespace GoldenEye.Kafka.Producers;

public class KafkaProducer: IExternalEventProducer
{
    private readonly KafkaProducerConfig config;

    public KafkaProducer(
        IConfiguration configuration
    )
    {
        if (configuration == null)
            throw new ArgumentNullException(nameof(configuration));

        // get configuration from appsettings.json
        config = configuration.GetKafkaProducerConfig();
    }

    public async Task Publish(IExternalEvent @event, CancellationToken cancellationToken = default)
    {
        using (var p = new ProducerBuilder<string, string>(config.ProducerConfig).Build())
        {
            await Task.Yield();
            // publish event to kafka topic taken from config
            var result = await p.ProduceAsync(config.Topic,
                new Message<string, string>
                {
                    // store event type name in message Key
                    Key = @event.GetType().Name,
                    // serialize event to message Value
                    Value = JsonConvert.SerializeObject(@event)
                });
        }
    }
}