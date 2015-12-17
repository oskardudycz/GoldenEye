<?xml version="1.0" encoding="utf-8"?>
<!--
  For more information on how to configure your ASP.NET application, please visit
  http://go.microsoft.com/fwlink/?LinkId=301880
  -->
<configuration>
    <configSections>

        <section name="entityFramework" type="System.Data.Entity.Internal.ConfigFile.EntityFrameworkSection, EntityFramework, Version=6.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" requirePermission="false" />
        <!-- For more information on Entity Framework configuration, visit http://go.microsoft.com/fwlink/?LinkID=237468 -->
    </configSections>
    <connectionStrings>
        <add name="DBConnectionString" connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=GoldenEyeSample;Integrated Security=SSPI" providerName="System.Data.SqlClient" />
    </connectionStrings>
    <appSettings>
        <add key="webpages:Version" value="3.0.0.0" />
        <add key="webpages:Enabled" value="false" />
        <add key="ClientValidationEnabled" value="true" />
        <add key="UnobtrusiveJavaScriptEnabled" value="true" />
        <add key="IsInTestMode" value="true" />
    </appSettings>
    <system.web>
        <authentication mode="None" />
        <compilation debug="true" targetFramework="4.5" />
        <httpRuntime targetFramework="4.5" />
    </system.web>
    <system.webServer>
        <modules>
            <remove name="WebDAVModule" />
            <remove name="FormsAuthenticationModule" />
        </modules>

        <handlers>
            <remove name="ExtensionlessUrlHandler-Integrated-4.0" />
            <remove name="OPTIONSVerbHandler" />
            <remove name="TRACEVerbHandler" />
            <remove name="ExtensionlessUrlHandler-ISAPI-4.0_32bit" />
            <remove name="ExtensionlessUrlHandler-ISAPI-4.0_64bit" />
            <remove name="ExtensionlessUrlHandler-Integrated-4.0" />
            <remove name="WebDAV" />
            <add name="ExtensionlessUrlHandler-ISAPI-4.0_32bit" path="*." verb="GET,HEAD,POST,DEBUG,PUT,DELETE,PATCH,OPTIONS" modules="IsapiModule" scriptProcessor="%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll" preCondition="classicMode,runtimeVersionv4.0,bitness32" responseBufferLimit="0" />
            <add name="ExtensionlessUrlHandler-ISAPI-4.0_64bit" path="*." verb="GET,HEAD,POST,DEBUG,PUT,DELETE,PATCH,OPTIONS" modules="IsapiModule" scriptProcessor="%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll" preCondition="classicMode,runtimeVersionv4.0,bitness64" responseBufferLimit="0" />
            <add name="ExtensionlessUrlHandler-Integrated-4.0" path="*." verb="GET,HEAD,POST,DEBUG,PUT,DELETE,PATCH,OPTIONS" type="System.Web.Handlers.TransferRequestHandler" preCondition="integratedMode,runtimeVersionv4.0" />

        </handlers>
    </system.webServer>
    <runtime>
        <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
            <dependentAssembly>
                <assemblyIdentity name="Microsoft.Owin" publicKeyToken="31bf3856ad364e35" />
                <bindingRedirect oldVersion="0.0.0.0-3.0.1.0" newVersion="3.0.1.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="System.Web.Optimization" publicKeyToken="31bf3856ad364e35" />
                <bindingRedirect oldVersion="1.0.0.0-1.1.0.0" newVersion="1.1.0.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="WebGrease" publicKeyToken="31bf3856ad364e35" />
                <bindingRedirect oldVersion="0.0.0.0-1.6.5135.21930" newVersion="1.6.5135.21930" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="Newtonsoft.Json" publicKeyToken="30ad4fe6b2a6aeed" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-7.0.0.0" newVersion="7.0.0.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="Microsoft.Owin.Security" publicKeyToken="31bf3856ad364e35" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-3.0.1.0" newVersion="3.0.1.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="Microsoft.Owin.Security.OAuth" publicKeyToken="31bf3856ad364e35" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-3.0.1.0" newVersion="3.0.1.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="Microsoft.Owin.Security.Cookies" publicKeyToken="31bf3856ad364e35" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-3.0.1.0" newVersion="3.0.1.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="Antlr3.Runtime" publicKeyToken="eb42632606e9261f" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-3.5.0.2" newVersion="3.5.0.2" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="System.Web.Helpers" publicKeyToken="31bf3856ad364e35" />
                <bindingRedirect oldVersion="1.0.0.0-3.0.0.0" newVersion="3.0.0.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="System.Web.WebPages" publicKeyToken="31bf3856ad364e35" />
                <bindingRedirect oldVersion="1.0.0.0-3.0.0.0" newVersion="3.0.0.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="System.Web.Mvc" publicKeyToken="31bf3856ad364e35" />
                <bindingRedirect oldVersion="0.0.0.0-5.2.3.0" newVersion="5.2.3.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="System.Web.Http" publicKeyToken="31bf3856ad364e35" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-5.2.3.0" newVersion="5.2.3.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="System.Net.Http.Formatting" publicKeyToken="31bf3856ad364e35" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-5.2.3.0" newVersion="5.2.3.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="Microsoft.Data.Edm" publicKeyToken="31bf3856ad364e35" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-5.7.0.0" newVersion="5.7.0.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="Microsoft.Data.OData" publicKeyToken="31bf3856ad364e35" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-5.7.0.0" newVersion="5.7.0.0" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="System.Spatial" publicKeyToken="31bf3856ad364e35" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-5.7.0.0" newVersion="5.7.0.0" />
            </dependentAssembly>
        </assemblyBinding>
    </runtime>
    <entityFramework>
        <defaultConnectionFactory type="System.Data.Entity.Infrastructure.SqlConnectionFactory, EntityFramework" />
        <providers>
            <provider invariantName="System.Data.SqlClient" type="System.Data.Entity.SqlServer.SqlProviderServices, EntityFramework.SqlServer" />
        </providers>
    </entityFramework>
</configuration>