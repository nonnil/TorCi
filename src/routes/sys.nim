import jester
import ../ views / [temp, sys]
import ".." / [types]
import ".." / lib / sys as libsys 
import ".." / lib / session

export sys

proc routingSys*(cfg: Config) =
  router sys:
    let tabForSys = Menu(
      text: @["Password", "Erase logs", "Update"],
      anker: @["/sys/passwd", "/sys/eraselogs", "/sys/update"]
    )

    get "/sys":
      redirect "/sys/passwd"
      #resp renderNode(renderPasswd(), request, cfg, menu=menu)

    post "/sys":
      let user = await getUser(request)
      if user.isLoggedIn:
        if request.formData["postType"].body == "chgPasswd":
          let code = await changePasswd(request.formData["crPassword"].body, request.formData["newPassword"].body, request.formData["re_newPassword"].body)
          if code:
            redirect("/login")
          else:
            redirect("/login")
        elif request.formData["postType"].body == "eraseLogs":
          let erased = await eraseLogs()
          if erased == success:
            resp renderNode(renderLogs(), request, cfg, user.uname, "", tabForSys, Notify(status: success, msg: "Complete erased logs"))
          elif erased == failure:
            resp renderNode(renderLogs(), request, cfg, user.uname, "", tabForSys, Notify(status: failure, msg: "Failure erased logs"))

    get "/sys/passwd":
      let user = await getUser(request)
      if user.isLoggedIn:
        # resp renderNode(renderCard("Change Passwd", renderPasswd()), request, cfg, tabForSys)
        resp renderNode(renderChangePasswd(), request, cfg, user.uname, "", tabForSys)
      redirect "/login"
    
    get "/sys/eraselogs":
      let user = await getUser(request)
      if user.isLoggedIn:
        resp renderNode(renderLogs(), request, cfg, user.uname, "", tabForSys)
      redirect "/login"