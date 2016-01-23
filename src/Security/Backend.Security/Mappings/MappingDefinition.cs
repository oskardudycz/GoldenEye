using AutoMapper;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Shared.Core.DTOs;
using GoldenEye.Shared.Core.Mappings;

namespace GoldenEye.Backend.Security.Mappings
{
    public class MappingDefinition : Profile, IMappingDefinition
    {
        protected override void Configure()
        {
            Mapper.CreateMap<UserDTO, User>()
                .IgnoreNonExistingProperties();
            Mapper.CreateMap<User, UserDTO>()
                .IgnoreNonExistingProperties();
        }
    }
}