using System.Runtime.Serialization;

namespace GoldenEye.Objects.Responses;

/// <summary>
///     Class to send single record from service.
///     Allows checkings of not null Item and inner data contract validation
/// </summary>
[DataContract]
public class SingleResponse<T>: ISingleResponse<T>
{
    public SingleResponse()
    {
    }

    /// <summary>
    ///     Constructor
    /// </summary>
    /// <param name="item">record</param>
    private SingleResponse(T item)
    {
        Item = item;
    }

    /// <summary>
    ///     Record
    /// </summary>
    [DataMember]
    public T Item { get; }

    //public static SingleResponse<T> Failure(FluentValidation.Results.ValidationResult returnInfo)
    //{
    //    return new SingleResponse<T>
    //    {
    //        ValidationResult = returnInfo
    //    };
    //}

    object ISingleResponse.Item
    {
        get { return Item; }
    }

    /// <summary>
    ///     Creation metod of class object
    /// </summary>
    /// <param name="item">Record</param>
    /// <returns></returns>
    public static SingleResponse<T> Create(T item)
    {
        return new SingleResponse<T>(item);
    }
}