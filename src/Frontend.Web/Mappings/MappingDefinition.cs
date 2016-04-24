using AutoMapper;
using GoldenEye.Frontend.Core.Web.Models;
using GoldenEye.Shared.Core.Mappings;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Frontend.Web.Mappings
{
    public class MappingDefinition : Profile, IMappingDefinition
    {
        protected override void Configure()
        {
            Mapper.CreateMap<RegisterBindingModel, UserDTO>().IgnoreNonExistingProperties();
        }
    }
}