using System.Threading;
using System.Threading.Tasks;
using MediatR;

namespace GoldenEye.Queries;

public class QueryBus: IQueryBus
{
    private readonly IMediator _mediator;

    public QueryBus(IMediator mediator)
    {
        _mediator = mediator;
    }

    public Task<TResponse> Send<TQuery, TResponse>(TQuery query, CancellationToken cancellationToken = default)
        where TQuery : IQuery<TResponse>
    {
        return _mediator.Send(query, cancellationToken);
    }
}