namespace :vapid do
  desc "Generate a VAPID key pair for web push. Copy the two keys into your .env (or Doppler)."
  task generate: :environment do
    keys = WebPush.generate_key
    puts "Add these to your .env (or Doppler), then restart:\n\n"
    puts "VAPID_PUBLIC_KEY=#{keys.public_key}"
    puts "VAPID_PRIVATE_KEY=#{keys.private_key}"
    puts "VAPID_SUBJECT=mailto:you@yourdomain.com"
  end
end
