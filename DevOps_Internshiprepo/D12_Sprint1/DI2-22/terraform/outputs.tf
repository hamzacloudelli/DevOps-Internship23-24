output "instanceVal1"{

    value = "Instance is Launcher -> ${aws_instance.web.availability_zone}"

}

output "instanceVal2"{

    value = "ID of the Instance -> ${aws_instance.web.id}"

}

output "volumeVal1" {

    value = "AZ of volume -> ${aws_ebs_volume.volume.availability_zone}"
    
}

output "volumeVal2" {

    value = "ID of Volume -> ${aws_ebs_volume.volume.id}"

}
