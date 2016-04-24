using System.Runtime.Serialization;

namespace GoldenEye.Shared.Core.Objects.Responses
{
    /// <summary>
    /// Class to send single record from service.
    /// Allows checkings of not null Item and inner data contract validation
    /// </summary>
    [DataContract]
    public class SingleResponse<T> : ResponseBase, ISingleResponse<T>
    {
        /// <summary>
        /// Record
        /// </summary>
        [DataMember]
        public T Item { get; set; }

        public SingleResponse()
        {
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="item">record</param>
        private SingleResponse(T item)
        {
            Item = item;
        }

        /// <summary>
        /// Creation metod of class object
        /// </summary>
        /// <param name="item">Record</param>
        /// <returns></returns>
        public static SingleResponse<T> Create(T item)
        {
            return new SingleResponse<T>(item);
        }

        public static SingleResponse<T> Failure(FluentValidation.Results.ValidationResult returnInfo)
        {
            return new SingleResponse<T>
            {
                ValidationResult = returnInfo
            };
        }

        object ISingleResponse.Item
        {
            get { return Item; }
            set { Item = (T)value; }
        }
    }
}