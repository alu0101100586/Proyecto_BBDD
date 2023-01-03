import os
import psycopg2

conn = psycopg2.connect(
        host="localhost",
        database="flask_db",
        #user=os.environ['DB_USERNAME'],
        #password=os.environ['DB_PASSWORD']
		    user='p7',
        password='p7passwd'
        )

# Open a cursor to perform database operations
cur = conn.cursor()

# Execute a command: this creates a new table
cur.execute('DROP TABLE IF EXISTS books;')
cur.execute('CREATE TABLE books (id serial PRIMARY KEY,'
                                 'title varchar (150) NOT NULL,'
                                 'author varchar (50) NOT NULL,'
                                 'pages_num integer NOT NULL,'
                                 'review text,'
                                 'date_added date DEFAULT CURRENT_TIMESTAMP);'
                                 )

# Insert data into the table

cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('A Tale of Two Cities',
             'Charles Dickens',
             489,
             'A great classic!')
            )


cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('Anna Karenina',
             'Leo Tolstoy',
             864,
             'Another great classic!')
            )
# Entradas añadidas a la base de datos
cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('La estrategia del pekinés',
             'Alexis Ravelo',
             245,
             'Una historia con un ritmo implacable!')
            )
cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('Memorias de Idhun',
             'Laura Gallego García',
             205,
             'Una trepidante historia de final agridulce.')
            )
cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('El palacio de la medianoche',
             'Carlos Ruiz Zafón',
             339,
             'Mortífero enigma de la ciudad de los palacios.')
            )
cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('Los espectros de nueva Ámsterdam',
             'Miguel Aguerralde',
             702,
             'Un lugar maldito que esconde una espantosa tragedia.')
            )
cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('El nombre del viento',
             'Patrick Rothfuss',
             920,
             'La nueva promesa de la literatura Fantástica.')
            )
cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('El temor de un hombre sabio',
             'Patrick Rothfuss',
             1362,
             'El tolkien estadounidense.')
            )
cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('Don Quijote',
             'Cervantes',
             462,
             'Texto que orienta la moral y la ética.')
            )
cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('El último pasajero',
             'Pablo Loureiro',
             448,
             'Un enorme trasatlántico llamado Valkirie aparece a la deriva en el océano Atlántico.')
            )
cur.execute('INSERT INTO books (title, author, pages_num, review)'
            'VALUES (%s, %s, %s, %s)',
            ('El Intermediario',
             'Mario Escobar',
             121,
             'Suspense, thriller y misterio en estado puro.')
            )

#cur.execute(
#            "RAISE EXCEPTION 'Duplicate title: %', title",
#            "USING ERRCODE = 'unique_violation';"
#            )
conn.commit()

cur.close()
conn.close()