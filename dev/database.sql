create table ubicaciones(
id_ubicacion serial primary key,
nombre varchar(30) not null,
direccion varchar(50) not null,
ciudad varchar(30) not null,
capacidad smallint not null check (capacidad > 0)
);
create table disponibilidades (
id_disponibilidad serial primary key,
fecha date not null,
hora_inicio time not null,
hora_fin time not null,
tipos_disponibilidad varchar(15) not null,
id_usuario int not null,
constraint fk_usuario_disponible
foreign key (id_usuario)
references usuarios(id_usuario),
constraint chk_tipo_dispo
check (tipos_disponibilidad in ('Disponible', 'Ocupado', 'No disponible')),
constraint chk_horas
check (hora_inicio < hora_fin)
);
create table tareas(
id_tarea serial primary key,
titulo varchar(150) not null,
descripcion text not null,
estado varchar(15) default 'Pendiente' check (estado in ('Pendiente', 'En progreso', 'Completada',
'Cancelada')),
prioridad varchar(10) default 'Media' check (prioridad in ('Baja', 'Media', 'Alta')),
fecha_limite timestamp not null,
id_evento int not null,
id_usuario int not null,
constraint fk_tarea_evento
foreign key (id_evento)
references eventos(id_evento),
constraint fk_tarea_usuario
foreign key (id_usuario)
references usuarios(id_usuario)
);
alter table eventos
add column id_ubicacion int references ubicaciones(id_ubicacion) on delete set null;
create or replace view vista_ocupacion_espacio as
select
ub.id_ubicacion,
ub.nombre as ubicacion,
ub.direccion,
ub.capacidad,
(select count(*) from eventos e where e.id_ubicacion=ub.id_ubicacion) as cantidad_eventos
from ubicaciones ub
order by cantidad_eventos desc;
create or replace view vista_disponibilidad_usuarios as
select
d.id_disponibilidad,
d.id_usuario,
u.nombre,
u.apellido,
d.fecha,
d.hora_inicio,
d.hora_fin,
d.tipos_disponibilidad
from disponibilidades d, usuarios u
where d.id_usuario = u.id_usuario;
create or replace view vista_tareas_asignadas AS
select
t.id_tarea,
u.id_usuario,
u.nombre AS nombre_usuario,
u.apellido AS apellido_usuario,
e.id_evento,
e.titulo AS evento,
t.titulo AS tarea,
t.descripcion,
t.estado,
t.prioridad,
t.fecha_limite
from tareas t, usuarios u, eventos e
where t.id_usuario = u.id_usuario
and t.id_evento = e.id_evento;