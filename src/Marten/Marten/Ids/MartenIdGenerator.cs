using System;
using GoldenEye.IdsGenerator;
using Marten;

namespace GoldenEye.Marten.Ids;

public class MartenIdGenerator : IIdGenerator
{
    private readonly IDocumentSession documentSession;

    public MartenIdGenerator(IDocumentSession documentSession)
    {
        this.documentSession = documentSession ?? throw new ArgumentNullException(nameof(documentSession));
    }

    public Guid New() => documentSession.Events.StartStream().Id;
}