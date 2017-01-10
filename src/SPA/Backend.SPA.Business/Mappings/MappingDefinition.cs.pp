using AutoMapper;
using GoldenEye.Backend.Security.Model;
using $rootnamespace$.Entities;
using Shared.Business.DTOs;
using GoldenEye.Shared.Core.Mappings;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Business.Mappings
{
    public class MappingDefinition : Profile, IMappingDefinition
    {
        public MappingDefinition()
        {
            CreateMap<TaskEntity, TaskDTO>(MemberList.None).ReverseMap();
            CreateMap<User, UserDTO>(MemberList.None).ReverseMap();
        }
    }
}