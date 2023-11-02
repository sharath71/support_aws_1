terraform { 
    backend "s3" {   
        bucket         = "testekstf"   
        key            = "prd/terraform.tfstate"   
        region         = "eu-north-1"
    }
}