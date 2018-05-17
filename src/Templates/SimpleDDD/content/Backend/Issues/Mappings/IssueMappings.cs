using System;
using AutoMapper;
using GoldenEye.Shared.Core.Mappings;
using IssueContracts = GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues;

namespace GoldenEye.WebApi.Template.SimpleDDD.Backend.Issues.Mappings
{
    internal class IssueMappings : Profile, IMappingDefinition
    {
        public IssueMappings()
        {
            CreateMap<IssueContracts.Commands.CreateIssue, Issue>().ConstructUsing(
                command => new Issue(Guid.NewGuid(), command.Type, command.Title, command.Description));
            CreateMap<IssueContracts.Commands.UpdateIssue, Issue>().ConvertUsing(
                (command, issue) => { issue.Update(command.Type, command.Title, command.Description); return issue; });

            CreateMap<Issue, IssueContracts.Events.IssueCreated>().ConstructUsing(
                aggregate => new IssueContracts.Events.IssueCreated(aggregate.Id, aggregate.Type, aggregate.Title, aggregate.Description));

            CreateMap<Issue, IssueContracts.Events.IssueUpdated>().ConstructUsing(
                aggregate => new IssueContracts.Events.IssueUpdated(aggregate.Id, aggregate.Type, aggregate.Title, aggregate.Description));

            CreateMap<Issue, IssueContracts.Events.IssueDeleted>().ConstructUsing(
                aggregate => new IssueContracts.Events.IssueDeleted(aggregate.Id));
        }
    }
}