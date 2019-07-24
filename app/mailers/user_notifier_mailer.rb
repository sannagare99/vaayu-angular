class UserNotifierMailer < ApplicationMailer
  default template_path: 'mailers/user_create'

  def user_create(user, token='')
    @user = user
    @token = token
    attachments.inline['logo-dark.png'] = File.read('app/assets/images/logo-dark.png')
    mail(
        to: user.email,
        subject: " Welcome to Vaayu"
    )
  end

end
