job "migration-guard-test-app" {
  datacenters = ["${datacenter}"]
  type        = "service"
  
  # Update policy
  update {
    max_parallel      = ${update_max_parallel}
    min_healthy_time  = "30s"
    healthy_deadline  = "5m"
    progress_deadline = "10m"
    auto_revert       = true
    auto_promote      = true
    canary            = ${canary_count}
    stagger           = "30s"
  }
  
  # Migrate strategy
  migrate {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "30s"
    healthy_deadline = "5m"
  }
  
  group "web" {
    count = ${web_count}
    
    # Restart policy
    restart {
      attempts = 3
      interval = "5m"
      delay    = "30s"
      mode     = "delay"
    }
    
    # Ephemeral disk
    ephemeral_disk {
      size    = 1024
      migrate = true
      sticky  = true
    }
    
    # Network configuration
    network {
      port "http" {
        to = 3000
      }
    }
    
    # Service registration
    service {
      name = "migration-guard-test-app-web"
      port = "http"
      tags = [
        "environment=${environment}",
        "version=${image_tag}",
        "traefik.enable=true",
        "traefik.http.routers.migration-guard-test-app.rule=Host(`${app_host}`)",
        "traefik.http.routers.migration-guard-test-app.entrypoints=websecure",
        "traefik.http.routers.migration-guard-test-app.tls=true",
        "traefik.http.routers.migration-guard-test-app.tls.certresolver=letsencrypt"
      ]
      
      check {
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
        
        check_restart {
          limit = 3
          grace = "90s"
        }
      }
    }
    
    # Rails web task
    task "rails" {
      driver = "docker"
      
      config {
        image = "${docker_image}"
        ports = ["http"]
        
        # Health check
        healthchecks {
          disable = false
        }
        
        # Logging
        logging {
          type = "json-file"
          config {
            max-size = "10m"
            max-file = "10"
          }
        }
      }
      
      # Environment variables
      env {
        RAILS_ENV              = "${rails_env}"
        RAILS_LOG_TO_STDOUT    = "true"
        RAILS_SERVE_STATIC_FILES = "true"
        PORT                   = "3000"
      }
      
      # Secrets from Vault
      template {
        data = <<EOH
DATABASE_URL="{{with secret "secret/data/migration-guard-test-app/${environment}/database"}}{{.Data.data.url}}{{end}}"
SECRET_KEY_BASE="{{with secret "secret/data/migration-guard-test-app/${environment}/rails"}}{{.Data.data.secret_key_base}}{{end}}"
REDIS_URL="{{with secret "secret/data/#{app_name}/\${environment}/redis"}}{{.Data.data.url}}{{end}}"
EOH
        destination = "secrets/app.env"
        env         = true
      }
      
      # Resources
      resources {
        cpu    = ${web_cpu}
        memory = ${web_memory}
      }
      
      # Vault policy
      vault {
        policies = ["migration-guard-test-app-${environment}"]
      }
    }
  }
  
  group "sidekiq" {
  count = ${sidekiq_count}
  
  restart {
    attempts = 3
    interval = "5m"
    delay    = "30s"
    mode     = "delay"
  }
  
  ephemeral_disk {
    size = 512
  }
  
  task "sidekiq" {
    driver = "docker"
    
    config {
      image = "${docker_image}"
      command = "bundle"
      args = ["exec", "sidekiq"]
      
      logging {
        type = "json-file"
        config {
          max-size = "10m"
          max-file = "10"
        }
      }
    }
    
    env {
      RAILS_ENV           = "${rails_env}"
      RAILS_LOG_TO_STDOUT = "true"
    }
    
    template {
      data = <<EOH
DATABASE_URL="{{with secret "secret/data/migration-guard-test-app/${environment}/database"}}{{.Data.data.url}}{{end}}"
SECRET_KEY_BASE="{{with secret "secret/data/migration-guard-test-app/${environment}/rails"}}{{.Data.data.secret_key_base}}{{end}}"
REDIS_URL="{{with secret "secret/data/migration-guard-test-app/${environment}/redis"}}{{.Data.data.url}}{{end}}"
EOH
      destination = "secrets/app.env"
      env         = true
    }
    
    resources {
      cpu    = ${sidekiq_cpu}
      memory = ${sidekiq_memory}
    }
    
    vault {
      policies = ["migration-guard-test-app-${environment}"]
    }
    
    service {
      name = "migration-guard-test-app-sidekiq"
      tags = [
        "environment=${environment}",
        "version=${image_tag}"
      ]
      
      check {
        type     = "script"
        command  = "/bin/sh"
        args     = ["-c", "ps aux | grep sidekiq | grep -v grep"]
        interval = "30s"
        timeout  = "5s"
      }
    }
  }
}
}
