﻿using System;
using AutoMapper;
using Backend.DDD.Sample.Contracts.Issues.Views;
using GoldenEye.Shared.Core.Mappings;
using IssueContracts = Backend.DDD.Sample.Contracts.Issues;

namespace Backend.DDD.Sample.Issues.Mappings
{
    internal class IssueMappings : Profile, IMappingDefinition
    {
        public IssueMappings()
        {
            CreateMap<IssueContracts.Commands.CreateIssue, Issue>().ConstructUsing(
                command => new Issue(Guid.NewGuid(), command.Type, command.Title));

            CreateMap<Issue, IssueContracts.Events.IssueCreated>().ConstructUsing(
                aggregate => new IssueContracts.Events.IssueCreated(aggregate.Id, aggregate.Type, aggregate.Title, aggregate.Description));

            CreateMap<Issue, IssueView>(MemberList.None);
        }
    }
}