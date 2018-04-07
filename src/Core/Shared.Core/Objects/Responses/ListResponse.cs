﻿using System.Collections.Generic;
using System.Runtime.Serialization;

namespace GoldenEye.Shared.Core.Objects.Responses
{
    /// <summary>
    /// Class to send list of records from service
    /// </summary>
    [DataContract]
    public class ListResponse<T> : ResponseBase, IListResponse<T>
    {
        /// <summary>
        /// List of records
        /// </summary>
        [DataMember]
        public IList<T> Items { get; }

        public ListResponse()
        {
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="items">List of records</param>
        public ListResponse(IList<T> items)
        {
            Items = items;
        }

        /// <summary>
        /// Creation metod of class object
        /// </summary>
        /// <param name="items">List of records</param>
        /// <returns></returns>
        public static ListResponse<T> Create(IList<T> items)
        {
            if (items == null)
                items = new List<T>();

            return new ListResponse<T>(items);
        }

        //public static ListResponse<T> Failure(FluentValidation.Results.ValidationResult returnInfo)
        //{
        //    return new ListResponse<T>
        //    {
        //        ValidationResult = returnInfo
        //    };
        //}
    }
}