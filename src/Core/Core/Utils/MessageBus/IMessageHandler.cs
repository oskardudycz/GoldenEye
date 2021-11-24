namespace GoldenEye.Utils.MessageBus;

public interface IMessageHandler<TMessage> where TMessage : class, IMessage, new()
{
    void HandleMessage(TMessage message);
}