import Config

# you need to docker-compose up a test instance of hexpm - see README
config :aura,
       repo_url: System.get_env("AURA_REPO_URL", "http://localhost:4000/api")
