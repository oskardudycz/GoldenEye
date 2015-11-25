using System.Linq;
using System.Net;
using System.Threading.Tasks;
using System.Web.Http;
using Backend.Core.Service;
using Shared.Core.DTOs;
using NLog;

namespace Frontend.Web.Core.Controllers
{
    public abstract class RestControllerBase<TService, TDto> : ReadonlyRestControllerBase<TService, TDto> where TDto : IDTO
        where TService : IRestService<TDto>
    {
        private static Logger logger = LogManager.GetCurrentClassLogger();
        protected RestControllerBase(TService service) : base(service)
        {
        }

        protected RestControllerBase()
        {
        }

        public virtual async Task<IHttpActionResult> Put(TDto dto)
        {

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await Service.Put(dto);

            logger.Info("Task added successfully.");
            logger.Error("Exception occured in the Put method.");
            logger.Fatal("Fatal error in the Put method.");

            return Ok(result);
        }

        public virtual async Task<IHttpActionResult> Post(TDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await Service.Post(dto);

            logger.Error("Exception occured in the Post method.");
            logger.Fatal("Fatal error in the Post method.");

            return Ok(result);
        }

        public async Task<IHttpActionResult> Delete(int id)
        {
            var wasDeleted = await Service.Delete(id);
            if (!wasDeleted)
            {
                return NotFound();
            }

            return StatusCode(HttpStatusCode.NoContent);
        }
    }
}
