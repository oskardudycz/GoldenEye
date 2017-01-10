using AutoMapper;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Shared.Business.DTOs;
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