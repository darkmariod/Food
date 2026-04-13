import os
from datetime import datetime

from dotenv import load_dotenv
from sqlalchemy import JSON, Boolean, Column, DateTime, Float, String, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

load_dotenv()
DATABASE_URL = os.getenv("sb_secret_tA3QBSY8wqhHCd47y0nyeA_duZC0_BA")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class Producto(Base):
    __tablename__ = "productos"
    id = Column(
        String, primary_key=True, default=lambda: str(datetime.now().timestamp())
    )
    nombre = Column(String, nullable=False)
    precio = Column(Float, default=0)
    descripcion = Column(String)
    categoria = Column(String, default="animal")
    activo = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.now)


class Pedido(Base):
    __tablename__ = "pedidos"
    id = Column(
        String, primary_key=True, default=lambda: str(datetime.now().timestamp())
    )
    cliente_nombre = Column(String, default="Cliente")
    cliente_telefono = Column(String)
    items = Column(JSON, default=[])
    total = Column(Float, default=0)
    estado = Column(String, default="pendiente")
    notas = Column(String)
    created_at = Column(DateTime, default=datetime.now)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    Base.metadata.create_all(bind=engine)
