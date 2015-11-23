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
            Mapper.CreateMap<Task, TaskDTO>()
                .ForMember(el=>el.Progress, opt=>opt.Ignore())
                .IgnoreNonExistingProperties();
            Mapper.CreateMap<TaskDTO, Task>()
                .ForMember(el => el.Progress, opt => opt.Ignore())
                .IgnoreNonExistingProperties();
            Mapper.CreateMap<ClientEntity, ClientDTO>().IgnoreNonExistingProperties();
            Mapper.CreateMap<ClientDTO, ClientEntity>().IgnoreNonExistingProperties();
            Mapper.CreateMap<TaskTypeEntity, TaskTypeDTO>().IgnoreNonExistingProperties();
            Mapper.CreateMap<TaskTypeDTO, TaskTypeEntity>().IgnoreNonExistingProperties();
            Mapper.CreateMap<RegisterBindingModel, UserDTO>().IgnoreNonExistingProperties();
            Mapper.CreateMap<UserDTO, UserEntity>().IgnoreNonExistingProperties();
        }
    }
}