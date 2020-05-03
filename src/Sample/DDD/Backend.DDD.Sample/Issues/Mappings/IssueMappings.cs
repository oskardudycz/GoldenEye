using System;
using AutoMapper;
using Backend.DDD.Sample.Contracts.Issues.Commands;
using Backend.DDD.Sample.Contracts.Issues.Events;
using Backend.DDD.Sample.Contracts.Issues.Views;
using GoldenEye.Shared.Core.Mappings;
using IssueContracts = Backend.DDD.Sample.Contracts.Issues;

namespace Backend.DDD.Sample.Issues.Mappings
{
    internal class IssueMappings: Profile, IMappingDefinition
    {
        public IssueMappings()
        {
            CreateMap<CreateIssue, Issue>().ConstructUsing(
                command => new Issue(Guid.NewGuid(), command.Type, command.Title));

            CreateMap<Issue, IssueCreated>().ConstructUsing(
                aggregate => new IssueCreated(aggregate.Id, aggregate.Type, aggregate.Title, aggregate.Description));

            CreateMap<Issue, IssueView>(MemberList.None);
        }
    }
}
