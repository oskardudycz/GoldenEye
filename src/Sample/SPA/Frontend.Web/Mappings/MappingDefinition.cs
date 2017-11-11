using AutoMapper;
using GoldenEye.Frontend.Core.Web.Models;
using GoldenEye.Shared.Core.Mappings;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Frontend.Web.Mappings
{
    public class MappingDefinition : Profile, IMappingDefinition
    {
        public MappingDefinition()
        {
            CreateMap<RegisterBindingModel, UserDTO>(MemberList.None);
        }
    }
}