using System.Collections.Generic;

namespace GoldenEye.Utils.MessageBus;

public interface IMessageBus
{
    void Subscribe<TMessage>(IMessageHandler<TMessage> handler) where TMessage : class, IMessage, new();

    void Unsubscribe<TMessage>(IMessageHandler<TMessage> handler) where TMessage : class, IMessage, new();

    void Publish<TMessage>(TMessage message) where TMessage : class, IMessage, new();

    IList<object> GetHandlers();
}