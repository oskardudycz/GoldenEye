using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Queries;
using Marten;
using Marten.Pagination;

namespace Tickets.Reservations.GettingReservationHistory;

public class GetReservationHistory : IQuery<IPagedList<ReservationHistory>>
{
    public Guid ReservationId { get; }
    public int PageNumber { get; }
    public int PageSize { get; }

    private GetReservationHistory(Guid reservationId, int pageNumber, int pageSize)
    {
        ReservationId = reservationId;
        PageNumber = pageNumber;
        PageSize = pageSize;
    }

    public static GetReservationHistory Create(Guid reservationId,int pageNumber = 1, int pageSize = 20)
    {
        if (pageNumber <= 0)
            throw new ArgumentOutOfRangeException(nameof(pageNumber));
        if (pageSize is <= 0 or > 100)
            throw new ArgumentOutOfRangeException(nameof(pageSize));

        return new GetReservationHistory(reservationId, pageNumber, pageSize);
    }
}

internal class HandleGetReservationHistory :
    IQueryHandler<GetReservationHistory, IPagedList<ReservationHistory>>
{
    private readonly IDocumentSession querySession;

    public HandleGetReservationHistory(IDocumentSession querySession)
    {
        this.querySession = querySession;
    }
    public Task<IPagedList<ReservationHistory>> Handle(GetReservationHistory request, CancellationToken cancellationToken)
    {
        return querySession.Query<ReservationHistory>()
            .Where(h => h.ReservationId == request.ReservationId)
            .ToPagedListAsync(request.PageNumber, request.PageSize, cancellationToken);
    }
}