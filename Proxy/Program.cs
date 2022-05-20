using Yarp.ReverseProxy.Transforms;

var builder = WebApplication.CreateBuilder(args);

_ = builder.Services.AddReverseProxy()
                    .AddTransforms(builderContext =>
                    {
                        builderContext.CopyRequestHeaders = true;
                        builderContext.AddOriginalHost(useOriginal: true);
                        builderContext.UseDefaultForwarders = true;
                    })
                    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

app.MapReverseProxy();
app.MapGet("/proxy", () => "Hello from YARP!");

app.Run();
