using System;
using Backend.DDD.Contracts.Sample.Issues;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.Objects.General;

namespace Backend.DDD.Sample.Issues
{
    internal class Issue : IEntity
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
    }
}