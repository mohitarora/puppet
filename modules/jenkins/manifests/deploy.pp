# This module will download the artifact from jenkins and deploy it on the target location.
define jenkins::deploy(
   $artifact_url,
   $artifact_name,
   $username = 'marora',
   $password = 'XXXXXX',
   $artifact_type = 'zip',
   $destination_dir
   ) {

	exec { "download-artifact-${artifact_name}":
		cwd => "/tmp",
		command => "/usr/bin/wget -q --http-user=$username --http-password=$password --auth-no-challenge $artifact_url/$artifact_name",
		creates => "/tmp/$artifact_name",
	}

	exec { "create-destination-${artifact_name}":
		command => "/bin/mkdir -p $destination_dir",
		creates => "$destination_dir",
		require => Exec["download-artifact-${artifact_name}"],
	}
	
	if $artifact_type == 'tar' {
		exec { "install-tar-artifact-${artifact_name}":
			cwd => "$destination_dir",
			command => "/bin/tar xvf /tmp/$artifact_name",
			require => [Exec["create-destination-${artifact_name}"] , Exec["download-artifact-${artifact_name}"]],
		}
	}
	elsif $artifact_type == 'zip' {
      exec { "install-zip-artifact-${artifact_name}":
			cwd => "$destination_dir",
			command => "/usr/bin/unzip -o /tmp/$artifact_name",
			require => [Exec["create-destination-${artifact_name}"] , Exec["download-artifact-${artifact_name}"]],
		}
   }
   elsif $artifact_type == 'tar.gz' {
		exec { "install-gztar-artifact-${artifact_name}":
			cwd => "$destination_dir",
			command => "/bin/tar xvzf /tmp/$artifact_name",
			require => [Exec["create-destination-${artifact_name}"] , Exec["download-artifact-${artifact_name}"]],
		}
   }
   elsif $artifact_type == 'war' {
		exec { "install-war-artifact-${artifact_name}":
			cwd => "$destination_dir",
			command => "/bin/cp /tmp/$artifact_name .",
			require => [Exec["create-destination-${artifact_name}"] , Exec["download-artifact-${artifact_name}"]],
		}
   }
   else {
      notify {"Artifact can not be downloaded from Jenkins":}
   }
}