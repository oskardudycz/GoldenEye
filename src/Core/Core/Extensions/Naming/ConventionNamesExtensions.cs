using System.Linq;

namespace GoldenEye.Extensions.Naming;

public static class ConventionNamesExtensions
{
    /// <summary>
    ///     Class name ending used for non-conventional plural form (ex. Entity => Entities)
    /// </summary>
    public static char NonDefaultClassNameEnding { get { return 'y'; } }

    /// <summary>
    ///     Property name ending used for non-conventional plural form (ex. Entity => Entities)
    /// </summary>
    public static string NonDefaultPropertyNameEnding { get { return "ies"; } }

    /// <summary>
    ///     Property name ending used for conventional plural form (ex. Administrator => Administrators)
    /// </summary>
    public static char DefaultPropertyNameEnding { get { return 's'; } }

    /// <summary>
    ///     (ex. Tax => Taxes)
    /// </summary>
    public static char NonDefaultClassNameEnding_X { get { return 'x'; } }

    public static string NonDefaultPropertyNameEnding_X { get { return "es"; } }

    /// <summary>
    ///     (ex. Status => Statuses)
    /// </summary>
    public static char NonDefaultClassNameEnding_S { get { return 's'; } }

    public static string NonDefaultPropertyNameEnding_S { get { return "es"; } }

    /// <summary>
    ///     Return plural form from entity class (ex. class named "Dog" returns "Dogs")
    /// </summary>
    /// <param name="singleForm">String containing word in single form</param>
    /// <returns>String containing the plural form</returns>
    public static string GetPluralForm(this string singleForm)
    {
        var pluralForm = string.Empty;
        var lastLetter = singleForm.ToCharArray().Last();
        if (lastLetter == NonDefaultClassNameEnding)
            pluralForm = singleForm.Substring(0, singleForm.Length - 1) + NonDefaultPropertyNameEnding;
        else if (lastLetter == NonDefaultClassNameEnding_X)
            pluralForm = singleForm + NonDefaultPropertyNameEnding_X;
        else if (lastLetter == NonDefaultClassNameEnding_S)
            pluralForm = singleForm + NonDefaultPropertyNameEnding_S;
        else
            pluralForm = singleForm + DefaultPropertyNameEnding;

        return pluralForm;
    }
}