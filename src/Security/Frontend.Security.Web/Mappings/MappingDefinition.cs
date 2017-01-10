using AutoMapper;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Frontend.Core.Web.Models;
using GoldenEye.Shared.Core.Mappings;

namespace GoldenEye.Frontend.Security.Web.Mappings
{
    public class MappingDefinition : Profile, IMappingDefinition
    {
        public MappingDefinition()
        {
            CreateMap<RegisterBindingModel, User>(MemberList.None);
            CreateMap<RegisterExternalBindingModel, User>(MemberList.None);
        }
    }
}