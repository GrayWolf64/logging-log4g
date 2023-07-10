local DETAIL = Log4g.API.LoggerContextFactory.GetContext("DETAIL")
print(DETAIL:GetName())
DETAIL:Terminate()