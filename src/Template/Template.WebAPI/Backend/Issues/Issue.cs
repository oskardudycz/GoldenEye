using System;
using Backend.Contracts.Issues;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Shared.Core.Objects.General;

namespace Backend.Issues
{
    public class Issue : IEvent, IHasId
    {
        object IHasId.Id => Id;

        public Guid Id { get; private set; }

        public IssueType Type { get; private set; }

        public string Title { get; private set; }

        public string Description { get; private set; }

        public Issue()
        {
        }

        public Issue(Guid id, IssueType type, string title)
        {
            Id = id;
            Type = type;
            Title = title;
        }

        public Guid StreamId => Id;
    }
}