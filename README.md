# Despliegue de WordPress con Terraform y Ansible

Este proyecto permite desplegar una instancia de WordPress utilizando Terraform para aprovisionar la infraestructura y Ansible para configurar el software.

## Requisitos previos

- Terraform instalado
- Ansible instalado
- Credenciales de acceso al proveedor de nube (AWS, Azure, Google Cloud, etc.)

## Estructura del proyecto

- `roles/`: Contiene los roles de Ansible para configurar WordPress y sus dependencias.
- `templates/`: Plantillas utilizadas por Ansible para generar archivos de configuración.
- `.gitattributes`: Atributos especiales para archivos en Git.
- `ansible.cfg`: Archivo de configuración de Ansible.
- `hosts`: Inventario de hosts para Ansible.
- `main.tf`: Archivo principal de Terraform que define los recursos a aprovisionar.
- `playbook.yml`: Playbook de Ansible para configurar WordPress en la infraestructura aprovisionada.
- `terraform.tfstate`: Estado actual de la infraestructura aprovisionada por Terraform.
- `terraform.tfstate.backup`: Copia de seguridad del estado de Terraform.
- `variables.tf`: Variables utilizadas en la configuración de Terraform.
- `wpserver.pem`: Llave privada para acceder a las instancias aprovisionadas (no incluir en el repositorio).

## Uso

1. Clonar este repositorio.
2. Configurar las credenciales de acceso al proveedor de nube.
3. Ajustar las variables en `variables.tf` según sea necesario. 
4. Ejecutar `terraform init` para inicializar el directorio de trabajo.
5. Ejecutar `terraform apply` para aprovisionar la infraestructura.
6. Una vez aprovisionada, ejecutar `ansible-playbook playbook.yml` para configurar WordPress.
7. Acceder a la instancia de WordPress desplegada utilizando la IP o DNS proporcionados.

## Personalización

- Los roles de Ansible pueden modificarse en la carpeta `roles/` para ajustar la configuración.
- Las plantillas en `templates/` permiten personalizar los archivos de configuración.
- Ajustar `main.tf` y `variables.tf` para modificar el aprovisionamiento de infraestructura.

## Limpieza 

Para destruir la infraestructura aprovisionada cuando ya no sea necesaria:

1. Ejecutar `terraform destroy`
2. Confirmar la acción escribiendo `yes` cuando se solicite.

Esto eliminará todos los recursos creados por Terraform de acuerdo al estado actual.
