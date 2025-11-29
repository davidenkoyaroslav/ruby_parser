require 'sidekiq'
require 'pony'

module MyApplicationDavydenko
  class ArchiveSender
    include Sidekiq::Worker

    def perform(path)
      Pony.mail(
        to: "example@mail.com",
        subject: "Archive",
        body: "Attached archive.",
        attachments: { "archive.zip" => File.binread(path) }
      )
    end
  end
end
