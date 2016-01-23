using AutoMapper;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Frontend.Core.Web.Models;
using GoldenEye.Shared.Core.Mappings;

namespace GoldenEye.Frontend.Security.Web.Mappings
{
    public class MappingDefinition : Profile, IMappingDefinition
    {
        protected override void Configure()
        {
            Mapper.CreateMap<RegisterBindingModel, User>()
                .IgnoreNonExistingProperties();
            Mapper.CreateMap<RegisterExternalBindingModel, User>()
                .IgnoreNonExistingProperties();
        }
    }
}