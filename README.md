martes, 28 febrero, 23:59

Evento de curso

# Proyecto “Barman”
 
Se pide crear una aplicación donde el usuario pueda consultar recetas de cockteles y crear sus propias recetas y guardarlas en su dispositivo.
 
* Descripción del app:
Cuando el usuario abre por primera vez el app, se muestran 15 bebidas precargadas, cada una de estas bebidas tiene su receta que el usuario puede ver al hacer touch sobre una de ellas. La receta consiste en el listado de ingredientes, las instrucciones de preparación y una foto para que puedas comparar como te debe quedar la bebida terminada. En la pantalla del listado de bebidas hay un botón “agregar”, si el usuario lo toca, se muestra la vista de la receta pero con los campos vacíos, de modo que se pueda capturar la receta y además, tomar una foto de la bebida terminada.
 
Puntos a calificar:
 
1. Descarga el archivo con las bebidas predeterminadas de la siguiente URL: http://janzelaznog.com/DDAM/iOS/drinks.json
2. Muestra el nombre de cada bebida en la vista inicial del app. Puedes usar TableView o CollectionView, como prefieras.
3. Cuando el usuario seleccione una bebida se debe mostrar la vista de detalle, con la información de esa bebida, y su imagen.
4. Las imágenes de cada bebida, se encuentran en http://janzelaznog.com/DDAM/iOS/drinksimages/[nombre_de_la_bebida]
Cuando se vea una bebida por primera vez, hay que validar si su imagen existe en la carpeta Documents del dispositivo, en caso contrario descárgala y guárdala.
5. En la vista inicial debe haber un botón para agregar una nueva receta. Cuando el usuario toque este botón se debe mostrar otra vista (podría ser la misma vista de detalle pero con los campos vacíos) donde el usuario puede capturar los ingredientes y las instrucciones de la receta.
6. Cuando el usuario registre su receta, puede agregarle una foto. Implementa lo necesario para poder utilizar la cámara del dispositivo, y guarda la foto tomada junto con las fotos descargadas, en la carpeta Documents.
7. Necesitas implementar la persistencia de la información, para que la vista inicial muestre las recetas predeterminadas y también las que agregue el usuario. Puedes usar CoreData o simplemente trabajar con el mismo archivo JSON.
8. Recuerda implementar la detección de la conexión a Internet y mostrar mensajes apropiados para que el usuario sepa si algo no funciona bien.
9. Recuerda implementar la comprobación de permisos para poder utilizar la cámara.
10. De forma general en todas tus apps, personaliza la interfaz utilizando colores, fuentes e imágenes.
11. PUNTO EXTRA: implementa la función de compartir la nueva receta que capture el usuario.

