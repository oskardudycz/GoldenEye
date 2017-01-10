using AutoMapper;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Shared.Core.Mappings;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Security.Mappings
{
    public class MappingDefinition : Profile, IMappingDefinition
    {
        public MappingDefinition()
        {
            CreateMap<UserDTO, User>(MemberList.None).ReverseMap();
        }
    }
}