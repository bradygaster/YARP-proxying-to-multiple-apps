using Yarp.ReverseProxy.Configuration;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddApplicationMonitoring("Proxy");

_ = builder.Services.AddReverseProxy()
                    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"))
                        .AddConfigFilter<CustomConfigFilter>();

var app = builder.Build();

app.MapReverseProxy();
app.MapGet("/proxy", () => "Hello from YARP!");

app.Run();
