using AutoMapper;
using GoldenEye.Backend.Security.Model;
using GoldenEye.SPA.Business.Sample.Entities;
using GoldenEye.Shared.Core.DTOs;
using GoldenEye.Shared.Core.Mappings;
using GoldenEye.SPA.Shared.Sample.DTOs;

namespace GoldenEye.SPA.Business.Sample.Mappings
{
    public class MappingDefinition : Profile, IMappingDefinition
    {
        protected override void Configure()
        {
            Mapper.CreateMap<TaskEntity, TaskDTO>()
                .IgnoreNonExistingProperties();
            Mapper.CreateMap<TaskDTO, TaskEntity>()
                .IgnoreNonExistingProperties();
            Mapper.CreateMap<User, UserDTO>()
                .IgnoreNonExistingProperties();
            Mapper.CreateMap<UserDTO, User>()
                .IgnoreNonExistingProperties();
        }
    }
}