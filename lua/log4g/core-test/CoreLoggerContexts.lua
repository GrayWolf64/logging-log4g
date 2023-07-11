local DETAIL = Log4g.API.LoggerContextFactory.GetContext("DETAIL")
print(DETAIL:GetName(), Log4g.Core.LoggerContext.getLoggerCount())
DETAIL:Terminate()