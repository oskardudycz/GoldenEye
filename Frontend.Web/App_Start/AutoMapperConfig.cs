using AutoMapper;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Frontend.Core.Web.Models;
using GoldenEye.Frontend.Web.Models;
using GoldenEye.Shared.Business.DTOs;
using GoldenEye.Shared.Core.DTOs;
using GoldenEye.Shared.Core.Mappings;

namespace GoldenEye.Frontend.Web
{
    public class AutoMapperConfig
    {
        public static void RegisterMappings()
        {
            Mapper.CreateMap<TaskEntity, TaskDTO>()
                .ForMember(el=>el.Progress, opt=>opt.Ignore())
                .IgnoreNonExistingProperties();
            Mapper.CreateMap<TaskDTO, TaskEntity>()
                .ForMember(el => el.Progress, opt => opt.Ignore())
                .IgnoreNonExistingProperties();
            Mapper.CreateMap<Customer, CustomerDTO>().IgnoreNonExistingProperties();
            Mapper.CreateMap<CustomerDTO, Customer>().IgnoreNonExistingProperties();
            Mapper.CreateMap<TaskTypeEntity, TaskTypeDTO>().IgnoreNonExistingProperties();
            Mapper.CreateMap<TaskTypeDTO, TaskTypeEntity>().IgnoreNonExistingProperties();
            Mapper.CreateMap<ModelerUserEntity, UserDTO>().IgnoreNonExistingProperties();
            Mapper.CreateMap<UserDTO, ModelerUserEntity>().IgnoreNonExistingProperties();
            Mapper.CreateMap<RegisterBindingModel, UserDTO>().IgnoreNonExistingProperties();
        }
    }
}