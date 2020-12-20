using System;
using Backend.DDD.Sample.Contracts.Issues;
using GoldenEye.Aggregates;
using GoldenEye.Entities;
using GoldenEye.Objects.General;

namespace Backend.DDD.Sample.Issues
{
    public class Issue: Aggregate
    {
        public IssueType Type { get; private set; }

        public string Title { get; private set;  }

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
