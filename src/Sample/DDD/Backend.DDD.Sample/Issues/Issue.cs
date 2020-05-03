using System;
using Backend.DDD.Sample.Contracts.Issues;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.Objects.General;

namespace Backend.DDD.Sample.Issues
{
    internal class Issue: IEntity
    {
        public Issue()
        {
        }

        public Issue(Guid id, IssueType type, string title)
        {
            Id = id;
            Type = type;
            Title = title;
        }

        public Guid Id { get; }

        public IssueType Type { get; }

        public string Title { get; }

        public string Description { get; private set; }
        object IHaveId.Id => Id;
    }
}
