using AutoMapper;
using Backend.Business.Context;
using Backend.Business.Entities;
using Shared.Business.DTOs;
using Frontend.Web.Extensions;
using Frontend.Web.Models;

namespace Frontend.Web.App_Start
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
            Mapper.CreateMap<UserDTO, UserEntity>().IgnoreNonExistingProperties();
        }
    }
}